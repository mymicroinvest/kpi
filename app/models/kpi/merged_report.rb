module KPI
  class MergedReport
    def initialize(*args, &block)
      raise ArgumentError, "Should have any argument" if args.length == 0
      raise Exception unless block_given?

      @_reports ||= args
      @_merge = block
    end
    
    def entries
      Enumerator.new do |yielder|
        defined_kpis.each do |kpi_method|
          yielder.yield(send(kpi_method))
        end
      end
    end
  
    def title
      self.class.name
    end
    
    def defined_kpis
      @_reports.map(&:defined_kpis).inject(&:&)
    end

    def method_missing(name, *args)
      result = merge_proc_call(name)
      orginal = @_reports.first.send(name.to_sym)
      description = (orginal.description && result.description ? result.description.gsub("$$", orginal.description) : nil)

      KPI::Entry.new(result.name.gsub("$$", orginal.name),
                     result.value,
                     :description => description,
                     :unit => (result.unit || orginal.unit))
    end
    
    private
    
    def merge_proc_call(name)
      sym_name = name.to_sym
      @_merge.call(*@_reports.map(&sym_name))
    end
  end
end
