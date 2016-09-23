module Esites
  class Logger
    def self._log(line, color=39, should_print=true)
      p = "\e[90m[#{Time.now.strftime("%H:%M:%S")}]: ▸\e[0m \e[#{color}m#{line}\e[0m"
      if should_print == true
        print("#{p}\n")
      end
      return p
    end

    def self.error(line, should_print=true)
      return _log("[ERROR] #{line}", 31, should_print)
    end

    def self.success(line, should_print=true)
      return _log(line, 92, should_print)
    end

    def self.info(line, should_print=true)
      return _log(line, 93, should_print)
    end

    def self.debug(line, should_print=true)
      return _log(line, 36, should_print)
    end

    def self.log(line, should_print=true)
      return _log(line, 39, should_print)
    end

    private_class_method :_log
  end
end
