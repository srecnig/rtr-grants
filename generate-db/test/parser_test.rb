# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/parser'

class ParserTest < Minitest::Test
  def test_raises_error_if_no_data_key
    json_data = { 'hugo' => [] }
    assert_raises(RuntimeError) { RtrDataParser::Parser.new(json_data, 'rtr_data') }
  end

  def test_raises_error_if_no_complete_data_point
    json_data = { 'data' => [{
      'unternehmensverbund' => nil,
      'foerderungsnehmer' => 'AHVV Verlags GmbH',
      'sendername_druckschrift' => 'HEUTE',
      'projekttitel' => 'HEUTE for Future Weiterentwicklung',
      'foerderungsart' => 'Projektförderung Digitale Transformation',
      'kategorie' => 'Print',
      'subkategorie' => 'Tageszeitung',
      'foerderbetrag' => 210_000.00,
      'jahr' => 2022,
      'einreichtermin' => '1. Einreichtermin'

    }] }
    assert_raises(RuntimeError) { RtrDataParser::Parser.new(json_data, 'rtr_data') }
  end

  def test_create_table_works
    json_data = { 'data' => [{
      'unternehmensverbund' => 'Irgendwer',
      'foerderungsnehmer' => 'AHVV Verlags GmbH',
      'sendername_druckschrift' => 'HEUTE',
      'projekttitel' => 'HEUTE for Future Weiterentwicklung',
      'foerderungsart' => 'Projektförderung Digitale Transformation',
      'kategorie' => 'Print',
      'subkategorie' => 'Tageszeitung',
      'foerderbetrag' => 210_000.00,
      'jahr' => 2022,
      'einreichtermin' => '1. Einreichtermin'

    }] }
    parser = RtrDataParser::Parser.new(json_data, 'rtr_data')
    create_table_statement = 'CREATE TABLE rtr_data (unternehmensverbund VARCHAR, ' \
                             'foerderungsnehmer VARCHAR, sendername_druckschrift VARCHAR, ' \
                             'projekttitel VARCHAR, foerderungsart VARCHAR, kategorie VARCHAR, ' \
                             'subkategorie VARCHAR, foerderbetrag DECIMAL, jahr INTEGER, ' \
                             'einreichtermin VARCHAR);'
    assert_equal create_table_statement, parser.create_table_sqlite
  end

  def test_insert_into_works
    json_data = { 'data' => [{
      'unternehmensverbund' => 'Irgendwer',
      'foerderungsnehmer' => 'AHVV Verlags GmbH',
      'sendername_druckschrift' => 'HEUTE',
      'projekttitel' => 'HEUTE for Future Weiterentwicklung',
      'foerderungsart' => 'Projektförderung Digitale Transformation',
      'kategorie' => 'Print',
      'subkategorie' => 'Tageszeitung',
      'foerderbetrag' => 210_000.00,
      'jahr' => 2022,
      'einreichtermin' => '1. Einreichtermin'
    }, {
      'unternehmensverbund' => nil,
      'foerderungsnehmer' => nil,
      'sendername_druckschrift' => 'HEUTE\'s tolles ding.',
      'projekttitel' => "'; DROP TABLE students; --",
      'foerderungsart' => nil,
      'kategorie' => nil,
      'subkategorie' => nil,
      'foerderbetrag' => nil,
      'jahr' => nil,
      'einreichtermin' => nil
    }] }
    parser = RtrDataParser::Parser.new(json_data, 'rtr_data')
    insert_into_statement0 = 'INSERT INTO rtr_data (unternehmensverbund, foerderungsnehmer, ' \
                             'sendername_druckschrift, projekttitel, foerderungsart, kategorie, ' \
                             'subkategorie, foerderbetrag, jahr, einreichtermin) VALUES (\'Irgendwer\', ' \
                             '\'AHVV Verlags GmbH\', \'HEUTE\', \'HEUTE for Future Weiterentwicklung\', ' \
                             '\'Projektförderung Digitale Transformation\', \'Print\', \'Tageszeitung\', 210000.0, ' \
                             '2022, \'1. Einreichtermin\');'
    insert_into_statement1 = 'INSERT INTO rtr_data (unternehmensverbund, foerderungsnehmer, sendername_druckschrift, ' \
                             'projekttitel, foerderungsart, kategorie, subkategorie, foerderbetrag, jahr, ' \
                             'einreichtermin) VALUES (NULL, NULL, \'HEUTE\'\'s tolles ding.\', ' \
                             '\'\'\'; DROP TABLE students; --\', NULL, NULL, NULL, NULL, NULL, NULL);'
    assert_equal insert_into_statement0, parser.insert_sqlite[0]
    assert_equal insert_into_statement1, parser.insert_sqlite[1]
  end
end
