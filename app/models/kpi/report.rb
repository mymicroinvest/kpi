module KPI
  class Report
    extend KPI::Report::SuppressMemoization
    extend KPI::Memoizable

    include KPI::Report::DynamicDefinitions

    blacklist :initialize, :collect!, :entries, :time, :title, :defined_kpis, :result, :active_result, :method_missing

    def initialize(*args)
      @options = args.extract_options!
      @time = @options[:time] || Time.now
      @title = @options[:title] || self.class.name
    end
    attr_reader :time, :title

    def collect!
      self.defined_kpis.each {|kpi_method| send(kpi_method) }
      self
    end

    def entries
      Enumerator.new do |yielder|
        self.class.defined_kpis.each do |kpi_method|
          yielder.yield(send(kpi_method))
        end
      end
    end

    def defined_kpis
      self.class.defined_kpis.map(&:to_sym)
    end

    def result(*args)
      KPI::Entry.new *args
    end

    def active_result(*args)
      options = args.extract_options!

      raise ArgumentError, "Wrong number of arguments (#{args.count} of 1..2)" unless args.count >= 1

      options[:name] = args.first
      options[:value] = args.second if args.second
      options[:report_type] = self.class.name
      options[:report_time] = time.to_time

      force_save = options.delete(:save)

      record = KPI::ActiveEntry.find_by(options.select { |o| o.in? [:name, :report_type, :report_time] }) || KPI::ActiveEntry.new(options)

      if block_given? && (record.new_record? || force_save)
        record.value = yield(record)
        record.save!
      end

      record
    end

    def method_missing(name, *args)
      # check if KPI exists in report if name of missing method has trailing '?'
      return kpi_exists?($1.to_sym) if (/(.*)\?/ =~ name.to_s)
      super
    end

    private

    def kpi_exists?(name)
      self.defined_kpis.include?(name.to_sym)
    end
  end
end
