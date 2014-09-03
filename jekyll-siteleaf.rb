require "siteleaf"
require "yaml"

# API settings
Siteleaf.api_key = 'dfb10451ea1916091602fe116fddd6ac'
Siteleaf.api_secret = '50e3b27aa1fe02fa9b156c97aecd3e86'

# site settings
extension = 'md' # set this to whatever extension you are using for your posts.
site_id = '527809a45dde22dc19000001'
# run this from the command line
# curl -X GET -u APIKEY:APISECRET https://api.siteleaf.com/v1/sites.json
# to get your site_id
page_id = '5292bca55dde227cdc0001fe' # blog page to import posts into
# blog page id to import posts into
# run this from the command line
# curl -X GET -u APIKEY:APISECRET https://api.siteleaf.com/v1/sites/:SITE_ID/pages.json
# to get your page_id.
test_mode = true # change to true to test your import

# get posts from Jekyll
files = Dir.glob("_posts/*.#{extension}")

# loop through and add posts to Siteleaf
files.each do |file|
  puts "Creating post..."

  # set up post
  post = Siteleaf::Post.new
  post.site_id = site_id
  post.parent_id = page_id

  # read file
  content = File.read(file)

  # get front matter and body from file
  contentparts = /---(.*)---(.*)/m.match(content)
  frontmatter = YAML.load(contentparts[1])
  post.body = contentparts[2].strip

  # parse frontmatter
  post.meta = []
  post.taxonomy = []
  frontmatter.each do |k,v|
    case k
    when 'title'
      post.title = v.strip
    when 'tags', 'category'
      post.taxonomy << {"key" => k.strip, "values" => (v.is_a?(Array) ? v.strip : [v])}
    else
      post.meta << {"key" => k.strip, "value" => v.strip}
    end
  end

  # get date and slug from filename
  fileparts = /([0-9]{4}\-[0-9]{2}\-[0-9]{2})\-([A-Za-z0-9\-]+)\.#{extension}/.match(file)
  post.published_at = fileparts[1]
  post.custom_slug = fileparts[2]

  # save
  puts test_mode ? post.inspect : post.save.inspect
end

# done!
puts "Success!"