require 'octokit'
module Github
  
  class Base
    #Constants for this class comes here
    CLASS_NAME_WITH_ISSUE = "Issues"
    ISSUES_RESOURCE_PATH = "issues"
    FILES_RESOURCE_PATH = "files"
    COMMITS_RESOURCE_PATH = "commits"
    OPEN_ISSUES = "open"
    CLOSED_ISSUES = "closed"
    
    include Enumerable

    def initialize(options = {})
      @options = options      
      authenticate
      #If you want to see full data, Please uncomment this line. Presently you can see a maximum of 30.
      #enable_pagination_by_default
    end

    def authenticate(token = @options[:client_id], secret = @options[:client_secret])
      client = Octokit::Client.new(:client_id => @options[:client_id], :client_secret => @options[:client_secret])
    end

    def metrics
      metrics = {total: all.join.to_i}
      metrics
    end
  
    def get_commits
       Octokit.commits("#{slug}").count      
    end

    def get_sha_for_latest_commit
      commits = Octokit.commits("#{slug}")
      data = [(commits || [])].flatten
      @options[:sha] =  data.first['sha']
    end

    def get_open_issues
      issues = Octokit.issues("#{slug}", :state => OPEN_ISSUES).count
    end 
    
    def get_closed_issues
      issues = Octokit.issues("#{slug}", :state => CLOSED_ISSUES).count
    end 
   
    def get_files
      files  = Octokit.tree("#{slug}", "#{sha_slug}", :recursive => true).tree
      files.count
    end 

    def all(options = {})
      data = []
      data << get_commits if resource_path.start_with?(COMMITS_RESOURCE_PATH)
      data << get_open_issues if resource_path.start_with?(OPEN_ISSUES)
      data << get_closed_issues if resource_path.start_with?(CLOSED_ISSUES)
      data << get_files if resource_path.start_with?(FILES_RESOURCE_PATH)
      data	
    end
   
    def enable_pagination_by_default  
      Octokit.auto_paginate = true
    end

    def sha
      @sha ||= []
    end       

    def slug
      "#{user}/#{repo}"
    end

    def sha_slug
      get_sha_for_latest_commit
      @options[:sha]
    end
 
    def user
      @options[:user_name]
    end

    def repo
      @options[:user_repo]
    end

    def resource_path
      #The resource path should match the camelCased class name with the
      #first letter downcased.  
      klass = self.class.name.split('::').last
      klass[0] = klass[0].chr.downcase
      klass
    end

    def resource(klass_name)
      klass_name = klass_name.to_s.split('_').map(&:capitalize).join
      _klasses[klass_name] ||= begin
        klass = Object.const_get "::Github::#{klass_name}"
        klass.new @options
      end
    end

   private 
      def _klasses
        @_klasses ||= {}
      end

  end
end
