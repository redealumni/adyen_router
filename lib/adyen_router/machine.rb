module AdyenRouter
  
  class Machine

    attr_reader :name, :host, :port

    def initialize(name, host, port)
      @name, @host, @port = name, host, port
    end

  end


end
