#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'
require 'wikidata_ids_decorator'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MembersPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links

  field :members do
    member_rows.map { |row| fragment(row => MemberRow).to_h }
  end

  private

  def member_table
    noko.xpath('//table[.//th[contains(.,"Diputado")]]')
  end

  def member_rows
    member_table.xpath('.//tr[td]')
  end
end

class MemberRow < Scraped::HTML
  field :id do
    tds[0].css('a/@wikidata').map(&:text).first
  end

  field :name do
    tds[0].text.tidy
  end

  field :area_id do
    tds[1].css('a/@wikidata').map(&:text).first
  end

  field :area do
    tds[1].css('a').map(&:text).first
  end

  field :party_id do
    tds[2].css('a/@wikidata').map(&:text).last
  end

  field :party do
    tds[2].css('a').map(&:text).last
  end

  private

  def tds
    noko.css('td')
  end
end

url = 'https://es.wikipedia.org/wiki/Anexo:Diputados_del_Congreso_Nacional_de_Honduras_2014-2018'
Scraped::Scraper.new(url => MembersPage).store(:members, index: %i[name area party])
