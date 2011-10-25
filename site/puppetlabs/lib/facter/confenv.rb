Facter.add("confenv") do
  setcode do

    path = nil
    [ '/usr/bin/puppet', '/usr/local/bin/puppet', '/opt/puppet/bin/puppet'].each do |puppet|
      if File.exists?( puppet )
        path = puppet
        break
      end
    end

    return "problem with environment" if path.nil?

    # Split it, in case it is PE. You can compare strings too, it's a little
    # dirty.
    if Facter.value( 'puppetversion' ).spit( ' ' )[0] > "2.7"
      env = %x{#{path} config print environment}.chomp
    else
      env = %x{#{path} agent --configprint environment}.chomp
    end

    env

  end
end
