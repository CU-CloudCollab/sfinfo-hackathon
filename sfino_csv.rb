#!/usr/bin/env ruby

require 'aws-sdk'
require 'mechanize'
require 'uri'

URL = "https://sfinfo.cit.cornell.edu/sfinfo_app/htdocs/vserver.php?vs_id="
puts "\"id\",\"name\",\"os\",\"status\",\"account\",\"dept\",\"division}\",\"owner\",\"storage\""

agent = Mechanize.new
cookie = Mechanize::Cookie.new("cuweblogin2", "#{ARGV[0]}")
cookie.domain = "sfinfo.cit.cornell.edu"
cookie.path = "/"
agent.cookie_jar.add(URL + "3000", cookie)

1000.times do |num|
  begin
  id = "#{3000 + num}"
  page = agent.get(URL + id)


  name = page.parser.xpath("/html/body/div[3]/div/div/table[1]/tr[3]/td[2]")[0].children[0].text
  os = page.parser.xpath("/html/body/div[3]/div/div/table[1]/tr[4]/td[2]")[0].children[0].text
  account = page.parser.xpath("/html/body/div[3]/div/div/table[1]/tr[11]/td/table/tr[2]/td[2]")[0].children[0].text.strip

  dept = page.parser.xpath("/html/body/div[3]/div/div/table[1]/tr[11]/td/table/tr[4]/td[1]")
  division = page.parser.xpath("/html/body/div[3]/div/div/table[1]/tr[11]/td/table/tr[4]/td[2]")

  if dept[0].children.empty?
    dept = ""
  else
    dept = dept[0].children[0].text.strip
  end


  if division[0].children.empty?
    division = ""
  else
    division = division[0].children[0].text.strip
  end

  owner = page.parser.xpath("/html/body/div[3]/div/div/table[3]/tr[1]/td[2]")[0].children[0].text
  owner_bracket = owner.index("[")
  owner = owner[0..owner_bracket-1].strip

  status = page.parser.xpath("/html/body/div[3]/div/div/table[1]/tr[2]/td[5]")[0].children[0].text.strip

  i = 2
  quit = false
  storage = 0
  mount_hash = {}

  begin
    space = page.parser.xpath("/html/body/div[3]/div/div/table[6]/tr[#{i}]/td[3]")
    mount = page.parser.xpath("/html/body/div[3]/div/div/table[6]/tr[#{i}]/td[1]")
    if space.empty?
      quit = true
    else
      unless mount_hash[mount[0].children[0].text]
        storage += space[0].children[0].text.to_f
        mount_hash[mount[0].children[0].text] = 1
      end
    end
    i += 1
  end until quit

  storage = storage.to_i.to_s
  owner = "Unknown" if owner.eql?("[  ]")

  puts "\"#{id}\",\"#{name}\",\"#{os}\",\"#{status}\",\"#{account}\",\"#{dept}\",\"#{division}\",\"#{owner}\",\"#{storage}\""
  rescue Exception => e
    puts e.message
  end
end
