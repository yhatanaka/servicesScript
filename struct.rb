#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# usage: ruby guide_fee.rb test/base/guide
# test: 
# base: 案件を出力
# guide_check: ガイド人数・従事時間・ガイド料の各項目数が同じか
# guide_fee_flat_csv: ガイドごとの支払い金額明細をベタでCSV出力
# ガイド受付システムからExportしたCSVファイルから、ガイドごとの支払い金額集計

require 'csv'
require 'pp'
require 'thinreports'

Category = Struct.new(:name, :items)
Item = Struct.new(:name, :unit_price)
@categories = [
	Category.new('Beauty', [
		Item.new('Synergistic Rubber Bag', '1654.0'),
		Item.new('Incredible Bronze Shirt', '4369.0'),
		Item.new('Aerodynamic Wool Gloves', '9254.0'),
		Item.new('Fantastic Iron Pants', '597.0'),
		Item.new('Fantastic Marble Clock', '3489.0'),
		Item.new('Mediocre Steel Watch', '5147.0'),
		Item.new('Gorgeous Granite Plate', '792.0')
	]),
	Category.new('Garden', [
		Item.new('Intelligent Linen Coat', '8706.0'),
		Item.new('Sleek Copper Chair', '6810.0')
	]),
	Category.new('Tools & Games', [
		Item.new('Small Granite Clock', '6731.0'),
		Item.new('Aerodynamic Leather Bag', '6238.0'),
		Item.new('Fantastic Rubber Hat', '6198.0'),
		Item.new('Aerodynamic Marble Shoes', '9603.0')
	])
]

def build_details
	@categories.each_with_object([]) do |category, details|
		# Add category row
		details << {
			id: 'item_category',
			items: {
				category_name: category.name
			}
		}
		category.items.each do |item|
			# Add item row
			details << {
				id: 'item_detail',
				items: {
					item_name: item.name,
					item_unit_price: item.unit_price
				}
			}
		end
	end
end

params = {
	type: :section,
	layout_file: '/Users/hatanaka/Downloads/template-2.tlf',
	params: {
		groups: [
			{
				details: build_details,
				footers: {
					overall: {
						items: {
							number_of_items: @categories.sum { |category| category.items.count },
							number_of_categories: @categories.count
						}
					}
				}
			}
		]
	}
}

Thinreports.generate(params, filename: "struct.pdf")
