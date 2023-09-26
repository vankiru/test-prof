# frozen_string_literal: true

number_regex = /\d+\.?\d{0,2}/
memory_human_regex = /#{number_regex}[KMGTPEZ]?B/
percent_regex = /#{number_regex}%/

describe "MemoryProf Minitest" do
  specify "with default options", :aggregate_failures do
    output = run_minitest("memory_prof", env: {"TEST_MEM_PROF" => "test"})

    expect(output).to include("MemoryProf results")
    expect(output).to match(/Final RSS: #{memory_human_regex}/)

    expect(output).to include("Top 5 examples (by RSS):")

    expect(output).to match(/allocates a lot \(\.\/memory_prof_fixture.rb:18\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates some \(\.\/memory_prof_fixture.rb:13\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates a few \(\.\/memory_prof_fixture.rb:8\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates a bit \(\.\/memory_prof_fixture.rb:29\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates nothing \(\.\/memory_prof_fixture.rb:25\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
  end

  specify "in RSS mode", :aggregate_failures do
    output = run_minitest("memory_prof", env: {"TEST_MEM_PROF" => "rss"})

    expect(output).to include("MemoryProf results")
    expect(output).to match(/Final RSS: #{memory_human_regex}/)

    expect(output).to include("Top 5 examples (by RSS):")

    expect(output).to match(/allocates a lot \(\.\/memory_prof_fixture.rb:18\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates some \(\.\/memory_prof_fixture.rb:13\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates a few \(\.\/memory_prof_fixture.rb:8\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates a bit \(\.\/memory_prof_fixture.rb:29\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates nothing \(\.\/memory_prof_fixture.rb:25\) – \+#{memory_human_regex} \(#{percent_regex}\)/)
  end

  specify "in allocations mode", :aggregate_failures do
    output = run_minitest("memory_prof", env: {"TEST_MEM_PROF" => "alloc"})

    expect(output).to include("MemoryProf results")
    expect(output).to match(/Total allocations: #{number_regex}/)

    expect(output).to include("Top 5 examples (by allocations):")

    expect(output).to match(/allocates a lot \(\.\/memory_prof_fixture.rb:18\) – \+#{number_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates some \(\.\/memory_prof_fixture.rb:13\) – \+#{number_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates a few \(\.\/memory_prof_fixture.rb:8\) – \+#{number_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates a bit \(\.\/memory_prof_fixture.rb:29\) – \+#{number_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates nothing \(\.\/memory_prof_fixture.rb:25\) – \+#{number_regex} \(#{percent_regex}\)/)
  end

  specify "with top_count", :aggregate_failures do
    output = run_minitest("memory_prof", env: {"TEST_MEM_PROF" => "alloc", "TEST_MEM_PROF_COUNT" => "3"})

    expect(output).to include("MemoryProf results")
    expect(output).to match(/Total allocations: #{number_regex}/)

    expect(output).to include("Top 3 examples (by allocations):")

    expect(output).to match(/allocates a lot \(\.\/memory_prof_fixture.rb:18\) – \+#{number_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates some \(\.\/memory_prof_fixture.rb:13\) – \+#{number_regex} \(#{percent_regex}\)/)
    expect(output).to match(/allocates a few \(\.\/memory_prof_fixture.rb:8\) – \+#{number_regex} \(#{percent_regex}\)/)
  end
end
