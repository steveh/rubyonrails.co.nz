# API access
class Github

  # Github user rornz followers
  def devs
    return YAML::load(File.read('tmp/devs.yml')) if File.exists?('tmp/devs.yml')

    number_of_followers = Octokit.user(ROR_GITHUB_USER).followers
    @devs ||= Octokit.followers(ROR_GITHUB_USER, per_page: number_of_followers)

    ROR_NZ_ORGANISATIONS.each do |org|
      @devs << Octokit.user(org)
    end

    File.open('tmp/devs.yml', 'w') do |f|
      f.write @devs.to_yaml
    end
    @devs
  end

  def projects
    projects = []
    devs.each do |dev|
      ojfile = "tmp/projects-from-#{dev['login']}.yml"
      if File.exists?(file)
        prects << YAML::load(File.read(file))
      else
        begin # github returns 403 if API limit exceeded
          user_projects = select_projects(Octokit.repositories(dev['login']))
          projects << user_projects
          File.open(file, 'w') do |f|
            f.write user_projects.to_yaml
          end
        rescue Exception => e
          Rails.logger.warn "API ISSUE: #{e}"
        end
      end
    end

    projects.flatten!
    projects.sort_by(&:watchers).reverse

  end

  private
    def select_projects(projects)
      projects.select do |repo|
        repo['watchers'] > ROR_REQUIRED_WATCHERS &&!repo.fork && repo['language'] =~ /Ruby|JavaScript/
      end
    end
end


