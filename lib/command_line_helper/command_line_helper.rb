class CommandLineHelper
  include SharedFunctions

  def ingest(args, env)
    @env_info = Hash.new
    @env_info.merge!(testrails: CommandLineHelper::testrails(args))
    if args.find {|arg| arg.downcase.include? "api"}
      @env_info.merge!(base_uri: CommandLineHelper::base_uri(args, env))
      @env_info.merge!(user: CommandLineHelper::auth_helper(args, env, @env_info))
    end
    @env_info
  end

  def self.testrails(args)
    if args.find {|arg| arg.downcase.include? "testrails"}
      testrails = args.find {|arg| arg.downcase.include? "testrails"}
      testrails = testrails.include?("=")? testrails.split('=')[1] : testrails
    else
      "false"
    end
  end

  def self.base_uri(args, env)
    if args.find {|arg| arg.downcase.include? 'baseuri'}
      base_uri = args.find{|arg| arg.downcase.include? "baseuri"}
      base_uri = base_uri.include?("=")? base_uri.split('=')[1] : base_uri
      if env['API']['base-uri'].key?base_uri
         base_uri = env['API']['base-uri'][base_uri]
      else
        puts ("""
        ... Uh Oh you've summoned the Base Uri Wizard.
        (∩｀-´)⊃━☆ﾟ.*･｡ﾟ
        The base uri you're trying to use doesn't exist.
        Please choose from:
        #{env['API']['base-uri']}
        """)
        Process.exit(0)
      end
    end
  end

  def self.auth_helper(args, env, who)
    if who[:base_uri].include? "lenel"
      if args.find {|arg| arg.downcase.include? 'building'}
        building = args.find{|arg| arg.downcase.include? "building"}
        building = building.include?("=")? building.split("=")[1] : building
        if env['auth']['lenel']['building'].key?building
          building
        else
          CommandLineHelper::building_error_message(env)
        end
      else
        CommandLineHelper::building_error_message(env)
      end
    elsif who[:base_uri].include? "qa"
      if args.find {|arg| arg.downcase.include? 'user'}
        user = args.find{|arg| arg.downcase.include? "user"}
        user = user.include?("=")? user.split("=")[1] : user
        if env['auth']['qa'].key?user
          user
        else
          CommandLineHelper::user_error_message(env)
        end
      else
        CommandLineHelper::user_error_message(env)
      end
    end
  end


  def self.building_error_message(env)
    puts ("""
          ... Uh Oh you've summoned the Lenel Building Wizard.
          (∩｀-´)⊃━☆ﾟ.*･｡ﾟ
          You either forgot to add a building to the command line or the building you're trying doesn't exist.
          Please choose from:
          #{env['auth']['lenel']['building'].keys}
    """)
    Process.exit(0)

  end
  def self.user_error_message(env)
    puts ("""
          ... Uh Oh you've summoned the User Wizard
          (∩｀-´)⊃━☆ﾟ.*･｡ﾟ
          you either forgot to add a user to the command line or the user you're trying doesn't exist.
          Please choose from:
          #{env['auth']['qa'].keys}
          """)
    Process.exit(0)
  end

end