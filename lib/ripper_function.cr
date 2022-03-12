require "html"
require "http"
require "json"
require "lexbor"
require "process"
require "file_utils"
include HTTP

FFMPEG_NAME="ffmpeg"

def rip_album_data(target_url)
	begin
		Process.run(FFMPEG_NAME)
	rescue
		puts "ffmpeg is not installed. Metadata will not be added to any saved files."
	end
	body=Client.get("#{target_url}").body
	parser=Lexbor::Parser.new(body)
	artist_name=parser.css("#name-section > h3:nth-child(2) > span:nth-child(1) > a:nth-child(1)").map(&.inner_text).to_a[0].to_s
	album_title=parser.css("h2.trackTitle").map(&.inner_text).to_a[0].to_s.gsub("\n","").strip(' ')
	puts "Artist: #{artist_name}"
	puts "Album: #{album_title}"
	if Dir.exists?(artist_name)==false
		Dir.mkdir(artist_name)
	end
	Dir.cd(artist_name)
	if Dir.exists?(album_title)==false
		Dir.mkdir(album_title)
	end
	Dir.cd(album_title)
	album_data=JSON.parse(parser.css("head > script:nth-child(39)").map(&.attribute_by("data-tralbum")).to_a[0].to_s)
	album_data["trackinfo"].as_a.each do |trackdata|
		file_url=""
		trackdata["file"].as_h.each do |val|
			file_url=val[1]
		end
		#puts trackdata
		title=trackdata["title"]
		track_num=trackdata["track_num"]
		puts "Saving track #{track_num}: #{title}"
		filename="#{track_num}. #{title}.mp3"
		Client.get(file_url.to_s) do |file_rsp|
			File.write(filename,file_rsp.body_io)
		end
		tmpfilename=".#{filename}"
		File.rename(filename,tmpfilename)
		begin
			Process.run(FFMPEG_NAME,args=["-i",tmpfilename,"-c","copy","-metadata","title=#{title}","-metadata","track=#{track_num}","-metadata","album=#{album_title}","-metadata","artist=#{artist_name}",filename])
			FileUtils.rm(tmpfilename)
		rescue
			File.rename(tmpfilename,filename)
		end
	end
	Dir.cd("..")
	Dir.cd("..")

end
