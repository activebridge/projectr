require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'https://projectr.io'
SitemapGenerator::Sitemap.sitemaps_path = 'shared/'
SitemapGenerator::Sitemap.create do
  PAGES.each do |p|
    add p, changefreq: :never
  end
end
SitemapGenerator::Sitemap.ping_search_engines
