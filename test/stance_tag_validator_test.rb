require "fileutils"
require "minitest/autorun"
require "tmpdir"
require "jekyll"
require_relative "../_plugins/stance_tag_validator"

class StanceTagValidatorTest < Minitest::Test
  SiteStub = Struct.new(:data, :source, :collections)

  def response_site(response)
    data = {
      "stance_filters" => {
        "tags" => ["Public Health"],
        "races" => ["US Senate"],
        "parties" => ["Independent"]
      },
      "stance_questions" => {
        "nj" => [
          {
            "id" => "nj-q1",
            "question" => "What policy do you support?",
            "tag" => "Public Health"
          }
        ]
      },
      "stance_responses" => { "nj" => [response] }
    }
    SiteStub.new(data, Dir.pwd, {})
  end

  def valid_response
    {
      "candidate_first_name" => "Ada",
      "candidate_last_name" => "Lovelace",
      "state" => "nj",
      "race" => "US Senate",
      "party" => "Independent",
      "question" => "nj-q1",
      "response" => "Evidence should guide policy."
    }
  end

  def team_site(source, entries)
    SiteStub.new({ "stance_team" => { "nj" => entries } }, source, {})
  end

  def assert_validation_fails
    capture_io do
      assert_raises(RuntimeError) { yield }
    end
  end

  def test_rejects_non_iso_date_strings
    response = valid_response.merge("date" => "09/21/2026")

    assert_validation_fails do
      StanceResponseValidator.validate(response_site(response))
    end
  end

  def test_accepts_iso_date_strings
    response = valid_response.merge("date" => "2026-09-21")

    StanceResponseValidator.validate(response_site(response))
  end

  def test_non_responder_cannot_reference_a_question
    response = valid_response.reject { |key, _| key == "response" }
                             .merge("did_not_respond" => true)

    assert_validation_fails do
      StanceResponseValidator.validate(response_site(response))
    end
  end

  def test_team_image_must_exist
    Dir.mktmpdir do |source|
      entries = [{ "image" => "missing.png", "alt" => "A team member" }]

      assert_validation_fails do
        StanceResponseValidator.validate_team_data(team_site(source, entries))
      end
    end
  end

  def test_team_image_requires_alt_text
    Dir.mktmpdir do |source|
      image_dir = File.join(source, "images", "stance_teams", "nj")
      FileUtils.mkdir_p(image_dir)
      FileUtils.touch(File.join(image_dir, "member.png"))
      entries = [{ "image" => "member.png", "alt" => " " }]

      assert_validation_fails do
        StanceResponseValidator.validate_team_data(team_site(source, entries))
      end
    end
  end

  def test_team_image_path_must_be_a_filename
    Dir.mktmpdir do |source|
      entries = [{ "image" => "../member.png", "alt" => "A team member" }]

      assert_validation_fails do
        StanceResponseValidator.validate_team_data(team_site(source, entries))
      end
    end
  end

  def test_team_image_cannot_be_listed_twice
    Dir.mktmpdir do |source|
      image_dir = File.join(source, "images", "stance_teams", "nj")
      FileUtils.mkdir_p(image_dir)
      FileUtils.touch(File.join(image_dir, "member.png"))
      entry = { "image" => "member.png", "alt" => "A team member" }

      assert_validation_fails do
        StanceResponseValidator.validate_team_data(team_site(source, [entry, entry.dup]))
      end
    end
  end

  def test_instagram_only_team_entry_remains_valid
    Dir.mktmpdir do |source|
      entries = [{ "instagram" => "https://www.instagram.com/p/example/" }]

      StanceResponseValidator.validate_team_data(team_site(source, entries))
    end
  end
end
