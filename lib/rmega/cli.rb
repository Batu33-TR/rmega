require 'optparse'
require 'io/console'
require 'yaml'

module Rmega
  module CLI
    module Helpers
      def cli_options
        $cli_options ||= {}
      end

      def cli_prompt_password
        print("Enter password: ")
        password = STDIN.noecho(&:gets)
        password = password[0..-2] if password.end_with?("\n")
        puts

        return password
      end

      def mega_url?(url)
        Nodes::Factory.url?(url)
      end

      def configuration_filepath
        File.expand_path('~/.rmega')
      end

      def read_configuration_file
        return unless File.exists?(configuration_filepath)
        cli_options = YAML.load_file(configuration_filepath)
        cli_options.keys.each { |k| cli_options[k.to_sym] = cli_options.delete(k) }
        puts "Loaded configuration file #{configuration_filepath}" if cli_options[:debug]
      rescue Exception => ex
        raise(ex) if cli_options[:debug]
      end

      def apply_cli_options
        Rmega.logger.level = ::Logger::DEBUG if cli_options[:debug]

        cli_options.each do |key, value|
          Rmega.options.__send__("#{key}=", value)
        end
      end

      def apply_opt_parser_options(opts)
        opts.on("-t NUM", "--thread_pool_size", "Number of threads to use") { |n|
          cli_options[:thread_pool_size] = n.to_i
        }

        opts.on("--proxy-addr ADDRESS", "Http proxy address") { |value|
          cli_options[:http_proxy_address] = value
        }

        opts.on("--proxy-port PORT", "Http proxy port") { |value|
          cli_options[:http_proxy_port] = value.to_i
        }

        opts.on("-u", "--user USER_EMAIL", "User email address") { |value|
          cli_options[:user] = value
        }

        opts.on("--pass [USER_PASSWORD]", "User password (if omitted will prompt for it)") { |value|
          cli_options[:pass] = value
        }

        opts.on("--debug", "Debug mode") {
          cli_options[:debug] = true
        }

        opts.on("-v", "--version", "Print the version number") {
          puts Rmega::VERSION
          puts Rmega::HOMEPAGE
          exit!(0)
        }
      end

      def traverse_storage(node, path, opts = {})
        path.gsub!(/^\/|\/$/, "")
        curr_part = path.split("/")[0] || ""
        last_part = (path.split("/")[1..-1] || []).join("/")

        if curr_part.empty?
          if node.type == :root or node.type == :folder
            return node
          else
            return nil
          end
        else
          n = node.folders.find { |n| n.name.casecmp(curr_part).zero? }
          n ||= node.files.find { |n| n.name.casecmp(curr_part).zero? } unless opts[:only_folders]

          if last_part.empty?
            return n
          else
            return traverse_storage(n, last_part)
          end
        end
      end

      def cli_rescue
        read_configuration_file
        apply_cli_options
        yield
      rescue Interrupt
        puts "\nInterrupted"
      rescue Exception => ex
        if cli_options[:debug]
          raise(ex)
        else
          $stderr.puts "\nERROR: #{ex.message}"
        end
      end
    end
  end
end
