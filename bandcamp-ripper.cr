require "option_parser"
require "ripper_function.cr"
if ARGV.size>0
	ARGV.each do |arg|
		rip_album_data(arg)
	end
	puts "all done!"
else
	puts "Usage:\n bandcamp-ripper albumURL1 albumURL2 albumURL3 ..."
end
