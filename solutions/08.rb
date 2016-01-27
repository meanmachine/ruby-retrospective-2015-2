class Spreadsheet
  class Error < RuntimeError
  end

  def initialize(sheet = '')
    @sheet = sheet.strip.split("\n").map(&:split)
  end

  def rows()
    @sheet
  end

  def empty?()
    @sheet.empty?
  end

  def cell_at(cell_index)
    row, column = convert_coordinates(cell_index)
    if row == -1 or column == -1
      raise Error, "Invalid cell index \'#{cell_index}\'"
    end
    if row > @sheet.size or column > @sheet[0].size
      raise Error, "Cell \'#{cell_index}\' does not exist"
    end
    @sheet[row][column]
  end

  def [](cell_index)
    cell = cell_at(cell_index)
    if cell[0] != "="
      cell
    else

    end
  end

  def to_s()
    @sheet.map { |row| row.join("\t") }.join "\n"
  end

  private

  def convert_coordinates(cell_index)
    row_index    = /[0-9]+$/.match(cell_index).to_s.to_i - 1
    column_chars = /^[A-Z]+/.match(cell_index).to_s.reverse.chars
    column_index = column_chars.map.with_index do |char, index|
      (26**index) * (("A".."Z").to_a.index(char).next)
    end.inject(:+) - 1
    [row_index, column_index]
  end

  def calculate_formula(formula)
    number = /^[0-9]+(.[0-9]+)?$/.match(formula)
  end
end