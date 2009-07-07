namespace :server do
  
  desc "server:convert_file_tlds"
  task :convert_file_tlds do
    servers = File.readlines("data/tld_serv_list").map do |line|
      line.chomp!
      line.gsub!(/^\s*(.*)\s*$/, '\1')
      line.gsub!(/\s*#.*$/, '')
      if line =~ /^([\w\d\.-]+)\s+([\w\d\.:-]+|[A-Z]+\s+.*)$/
        extension, instructions = $1, $2
        server, options = case
          when instructions == "NONE"
            [nil, { :adapter => Whois::Server::Adapters::None }]
          when instructions ==  "ARPA"
            [nil, { :adapter => Whois::Server::Adapters::Arpa }]
          when instructions =~ /^WEB (.*)$/
            [nil, { :adapter => Whois::Server::Adapters::Web, :web => $1 }]
          when instructions ==  "CRSNIC"
            ["whois.crsnic.net", { :adapter => Whois::Server::Adapters::Verisign }]
          when instructions ==  "PIR"
            ["whois.publicinterestregistry.net", { :adapter => Whois::Server::Adapters::Pir }]
          when instructions ==  "AFILIAS"
            ["whois.afilias-grs.info", { :adapter => Whois::Server::Adapters::Afilias }]
          when instructions ==  "NICCC"
            ["whois.nic.cc", { :adapter => Whois::Server::Adapters::Verisign }]
          else
            [instructions]
        end
        
        <<-RUBY
Whois::Server.define #{extension.inspect}, \
#{server.inspect}\
#{options.nil? ? "" : ", " + options.inspect}
        RUBY
      end
    end.reject { |value| value == '' || value.nil? }
    
    File.open("lib/whois/definitions/tlds.rb", "w+") do |f| 
      f.write(<<-HEADER)
# WARNING: This file is autogenerated. Don't edit manually.

      HEADER
      f.write(servers)
    end
    puts "Created file with #{servers.size} servers."
  end
  
end