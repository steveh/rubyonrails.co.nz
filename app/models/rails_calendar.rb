class RailsCalendar
  def events
    require 'open-uri'
    return YAML::load(File.read('tmp/events.yml')) if File.exists?('tmp/events.yml')
    url = URI.parse(ROR_CALENDAR)
    cal = url.read
    cal = Hash.from_xml(cal)
    @cal = cal['feed']['entry'].select{|event| Time.parse(event['published']) > 1.year.ago}
    @cal = @cal.map do |event|
      event['date'] = Date.parse(event['summary'].split('When:')[1].split('to')[0])
      event
    end
    @cal = @cal.sort_by {|event| event['date']}
    File.open('tmp/events.yml','w'){|f| f.write @cal.to_yaml}
    @cal
  end

  def future
    events.select {|event| event['date'] >= Date.today}
  end
end


