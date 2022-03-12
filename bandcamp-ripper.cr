require "option_parser"
require "ripper_function.cr"
if ARGV.size>0
	ARGV.each do |arg|
		rip_album_data(arg)
	end
	puts "all done!"
else
	puts "Usage:\n bandcamp-ripper album1,album2,album3..."
end
