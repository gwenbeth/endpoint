# ruby program to simulate directories
def create_dir(path)
  # There is no checking to make sure the parent directories exist as
  # the spec didn't specify how that is handled
  $files += [ path ]
end

def list()
  indent = 0
  $files.sort.each do |f|
    puts
    # count the number of / in the filename
    indent = f.gsub(/[^\/]/,'').length
    indent.times {print '  '}
    # strip the prefix off the name before printing
    puts f.gsub(/^.*\//,'')
  end
end

def move_dir(path, dest)
  # find the prefix for the source if given
  old_prefix_m = path.match(/^.*\//)
  if (old_prefix_m.nil?) then
    old_prefix = ''
  else
    old_prefix = old_prefix_m[0]
  end
  # make a pattern that matches
  old_prefix_pat = Regexp.new "^" + old_prefix
  # make a pattern that matches the path and all sub paths
  pat = Regexp.new "^" + path + "(/[^/]+)*"
  movedfiles = $files.select{|x| x =~ pat}.each do |f|
    # change the name of all affected files
    f.sub!(old_prefix_pat,dest+'/')
  end
end

def delete_dir(path)
  pat = Regexp.new "^" + path + "(/[^/]+)*"
  if ($files.select {|x| x == path}.length == 0) then
  # find the first that doesn't exist
    split = path.split('/')
    prefix = ""
    split.each do |d|
      if prefix == "" then
        prefix = d
      else
        prefix = prefix + '/' + d
      end
      break if $files.find_index(prefix).nil?
    end
    puts 
    puts "Cannot delete " + path + " - " + prefix + " does not exist"
  else
    $files.reject!{|x| x =~ pat}
  end
end


if ARGV.length == 1 then
  filename = ARGV[0]
else
  filename = 'testfile'
end
fileObj = File.new(filename, "r")
$files = []
puts
while (line = fileObj.gets)
  line.gsub!("\n","")
  puts line
  parsed_line = line.split(' ')
  case parsed_line[0]
  when 'CREATE'
    create_dir(parsed_line[1])
  when 'LIST'
    list
  when 'MOVE'
    move_dir(parsed_line[1],parsed_line[2])
  when 'DELETE'
    delete_dir(parsed_line[1])
  end
end
puts
fileObj.close
