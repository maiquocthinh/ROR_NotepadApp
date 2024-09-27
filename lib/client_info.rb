require 'net/http'
require 'json'

module ClientInfo
  def self.get_info_client(request)
    begin
      ip = request.remote_ip
      location = ip2location(ip)
      user_agent = UserAgent.parse(request.user_agent)
      device_type = determine_device_type(user_agent, request.user_agent)

      {
        ip: ip,
        location: "#{location[:country_name] } (#{location[:region_name] })",
        platform: user_agent.platform || 'unknown',
        browser: user_agent.browser || 'unknown',
        device_type: device_type
      }
    rescue StandardError => e
      puts "Error occurred: #{e.message}"
      nil
    end
  end

  private

  def self.ip2location(ip)
    uri = URI("http://apiip.net/api/check?ip=#{ip}&accessKey=e3d31808-d8f5-4341-b261-b2911c501d85&fields=countryName,regionName")
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    { country_name: data['countryName'] || 'unknown', region_name: data['regionName'] || 'unknown' }
  end

  def self.determine_device_type(user_agent, user_agent_string)
    if user_agent.mobile?
      'Mobile'
    elsif user_agent_string =~ /Tablet|iPad/i
      'Tablet'
    elsif user_agent_string =~ /Windows NT|Macintosh|Linux/i
      'Desktop'
    elsif user_agent.bot?
      'Bot'
    else
      'Unknown'
    end
  end

end


