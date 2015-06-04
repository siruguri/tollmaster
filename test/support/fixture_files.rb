module FixtureFiles
  def fixture_file(filename)
    File.open(File.join(Rails.root, 'test', 'fixtures', 'files', filename)).readlines.join ''
  end

  def fixture_file_as_io(filename)
    File.open(File.join(Rails.root, 'test', 'fixtures', 'files', filename))
  end
end
