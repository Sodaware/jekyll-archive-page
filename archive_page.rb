##
# Generates the "/blog/archives/" page
#
# Requires the "page-archives.html" template

module Jekyll
  
  ##
  # Custom page purely for archives
  class ArchivePage < Page
    
    ##
    # Initialize archives page
    def initialize(site, base)
      
      @site = site
      @base = base
      @dir  = site.config['archive_path']
      @name = 'index.html' # get this from config?
      
      self.process(@name)
      
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'page-archives.html')
      
      # Setup the title (if not set?)
      self.data['title'] = "Archives"
      
      # Grab the data we need:
      #   - A list of all years that contain posts
      #   - A list of all months that contain posts
      #   - A list of all posts, grouped by date (or we can do this in the template?)
      self.data['grouped_posts']       = self.get_grouped_posts
      self.data['years']               = self.data['grouped_posts'].keys
      self.data['month_abbreviations'] = Date::ABBR_MONTHNAMES
      self.data['month_names']         = Date::MONTHNAMES

      # page.archives
      #   [2001]
      #   [01] => array of posts
      #   
      #
      
    end
    
    def get_grouped_posts

      # Get date of first post
      start_year = site.posts.docs.first.data['date'].year
      end_year   = Date.today.year

      years      = (start_year..end_year).to_a
      post_map   = {}

      years.each do |year| 
        post_map[year] = Hash.new

        (1..12).each do |month| 
          post_map[year][month] = Array.new
        end
      end

      # Add each post
      site.posts.docs.each do |post|
        post_map[post.data['date'].year][post.data['date'].month] << post
      end

      return post_map

    end
    
  end
  
  class ArchivePageGenerator < Generator
    
    safe true
    priority :low
    
    ##
    # Generate 
    def generate(site)
      
      # Check for template
      throw "No 'page-archives' layout found." if !site.layouts.key? 'page-archives'
      
      # Grab data
      
      # Build the page and add
      archives = ArchivePage.new(site, site.source)
      archives.render(site.layouts, site.site_payload)
      archives.write(site.dest)
      site.pages << archives
      
    end

  end
    
end
