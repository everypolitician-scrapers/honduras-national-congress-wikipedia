#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//table[.//caption[contains(.,"Diputados")]]//tr[td]').each do |tr|
    tds = tr.css('td')
    data = { 
      name: tds[0].text.tidy,
      wikiname: tds[0].xpath('.//a[not(@class="new")]/@title').text,

      area: tds[1].text.tidy,
      area_wikiname: tds[1].xpath('.//a[not(@class="new")]/@title').text,

      party: tds[2].text.tidy,
      party_wikiname: tds[2].xpath('.//a[not(@class="new")]/@title').text,
    }
    ScraperWiki.save_sqlite([:name, :area, :party], data)
  end
end

scrape_list('https://es.wikipedia.org/wiki/Anexo:Diputados_del_Congreso_Nacional_de_Honduras_2014-2018')
