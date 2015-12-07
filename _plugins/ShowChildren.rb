# require 'pry'
# require 'pry-byebug'

def GetChildren(url, site)
  # Caching mechanism
  if !site['children']
    site['children'] = {}
  elsif site['children'] && site['children']["#{url}"]
    return site['children'][url]
  end

  # Array to be returned
  children = []

  # Break down URL
  parts = url.split('/')
  target_level = parts.count + 1

  # Loop over all the pages, performance improvements welcomed
  site['pages'].each do |page|
    level = page.url.split('/').count
    # Look for URLs of the same level (number of /) and sharing the same parent.
    next unless (level == target_level) && (page.url.include? url)
    element = {}
    element['url'] = page.url
    element['title'] = page.data['title']

    if page.data['weight']
      element['weight'] = page.data['weight']
    else
      element['weight'] = 1000
    end

    element['children'] = GetChildren(page.url, site)

    children.push(element)
  end

  children = children.sort { |x, y| x['weight'] <=> y['weight'] }

  # Caching
  site['children']["#{url}"] = children

  children
end

Jekyll::Hooks.register :pages, :pre_render do |page, payload|
  # binding.pry
  next unless payload['site']['show_children']
  next unless page.data['show_children']
  payload['page']['children'] = GetChildren(page.url, payload['site'])
  # binding.pry
end
