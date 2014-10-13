module Puppet::Parser::Functions
  newfunction(:subdirs, :type => :rvalue, :doc => <<-EOS
      Returns a hash of the elements that have ensure == absent.
    EOS
  ) do |args|
    #raise(Puppet::ArgumentError, "absents(): Wrong number of arguments given") if args.size != 1
    #raise(Puppet::ArgumentError, "absents(): First parameter must be a hash") if args[0].class != Hash

    #Hash[args[0].select{ |k, v| v['ensure'] == 'absent' }]
    path = File.dirname(args[0])
    if path == '.'
        return Array.new
    end
    subpaths = Array.new
    splitted = path.split('/')
    splitted.length.times do |i|
      subpath = splitted[0..i].join('/')
      if !subpath.empty?
        subpaths << subpath
      end
    end
    return subpaths
  end
end
