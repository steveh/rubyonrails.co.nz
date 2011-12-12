class PagesController < ApplicationController
  
  def home
    github = Github.new
    
    @developers = github.devs.sort_by{rand}
    @projects = github.projects
    
    @events = RailsCalendar.new.future.take(4)
  end
  
  def reset
    begin
      # TODO, this will be a cron job
      ['events', 'devs', 'projects'].each do |file|
        File.unlink("tmp/#{file}.yml")
      end

      render :text => "done"
    rescue
      render :text => "no files to remove"
    end
  end

end
