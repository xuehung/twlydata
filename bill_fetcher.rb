require "open-uri"
require "yaml"
require "json"


class Bill
	@@billFolder = "bills"
	@@filename = "update.yml"
	@@lastPage = 1 
	@@lastId = 1

	def init()
		if File.exist?(@@filename)
			update = YAML.load_file(@@filename)
			@@lastPage = update["last_page"]
			@@lastId = update["last_id"]
		end
	end

	def update()
		begin
			jsonStr = getPage(@@lastPage)
			json = JSON.parse(jsonStr)
			nextUrl = json["next"]
			json["results"].each do |result|
				billId = result['url'][/\d+/]
				puts "fetching page:#{@@lastPage} bill id:#{billId}"
				filepath = "#{@@billFolder}/#{billId}.json"
				if not File.exists?(filepath)
					File.open(filepath, "w") do |f|
						f.write(result.to_json)
						puts "Saving the bill into #{filepath}"
					end
				end
				#puts result
				#puts "-----------------"
			end
			@@lastPage += 1
		end while nextUrl
	end

	def getPage(pagenum)
		contents = URI.parse("https://twly.herokuapp.com/api/bill/?page=#{pagenum}&format=json").read
	end
end



p = Bill.new
p.init()
p.update()
