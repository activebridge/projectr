require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'https://projectr.io'
SitemapGenerator::Sitemap.create do
  add '/projects', changefreq: 'daily', priority: 0.9
end
