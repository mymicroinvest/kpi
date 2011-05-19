module KPI
  class Report
    module DynamicDefinitions
      module ClassMethods
        def method_added(name)
          unless self.method_blacklisted?(name) || suppressed_memoization?
            self.defined_kpis << name
            suppress_memoization { memoize name }
          end
        end

        def method_blacklisted?(name)
          KPI::Report.not_kpi_methods.include?(name) ||
          not_kpi_methods.include?(name) ||
          name =~ /_unmemoized_/ ||
          !self.instance_methods(true).map(&:to_sym).include?(name)
        end

        def blacklist(*methods)
          not_kpi_methods.push *methods
        end

        def defined_kpis
          @kpi_methods ||= []
        end

        def not_kpi_methods
          @not_kpi_methods ||= []
        end
      end

      def self.included(base)
        base.send(:extend, ClassMethods)
      end
    end
  end
end