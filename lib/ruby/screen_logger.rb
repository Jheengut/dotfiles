#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 
require 'logger'
class ScreenLogger
    @use_color = true
    class << self
        attr_accessor :use_color
    end

    def initialize(file)
        Logger.class_eval { alias :add_orig :add }
        @log = Logger.new(file)
        @log.datetime_format="%Y%m%d %H:%M:%S "
        @log.level = Logger::DEBUG
        @log.formatter = proc {|severity, time, progname, msg|
            "%s#%d [%5s] - %s: %s\n" %
            [ time.strftime(self.datetime_format) , $$, severity, progname, msg.to_s ]
        }
        @screen = Logger.new(STDOUT)
        @screen.datetime_format="%m-%d %H:%M:%S "
        @screen.level = Logger::INFO
        @screen.formatter = proc {|severity, time, progname, msg|
            "%s#%d [%5s] - %s: %s\n" %
            [ time.strftime(self.datetime_format) , $$, severity, progname, msg.to_s ]
        }
        class << @screen
            LEVELCOLOR = { 
                Logger::INFO => nil,
                Logger::DEBUG => nil,
                Logger::WARN => "\e[1;33m",
                Logger::ERROR => "\e[1;31m",
                Logger::FATAL => "\e[1;35m",
            }

            def add(severity, message = nil, progname = nil, &block)
                severity ||= UNKNOWN
                if @logdev.nil? or severity < @level
                    return true
                end
                progname ||= @progname
                if message.nil?
                    if block_given?
                        message = yield
                    else
                        message = progname
                        progname = @p
                    end
                end
                message = "#{LEVELCOLOR[severity]}#{message}\e[m"    if ScreenLogger.use_color and LEVELCOLOR[severity]
                @logdev.write( format_message(format_severity(severity), Time.now, progname, message))
                true
            end 
        end
    end

    def method_missing(method, *args, &block)
        @log.send(method, *args, &block)
        @screen.send(method, *args, &block)
    end
end

