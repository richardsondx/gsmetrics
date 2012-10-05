require 'google_drive'

module GSMetrics
  class Session
    def initialize email, password
      @email = email
      @password = password
    end

    def worksheet doc_title, worksheet_id
      Worksheet.new doc_title, worksheet_id, @email, @password
    end
  end

  class Error < StandardError
  end
private
  class Worksheet
    attr_accessor :check_worksheet_size
    def initialize doc_title, worksheet_title, email, password
      @doc_title = doc_title
      @worksheet_title = worksheet_title
      @email = email
      @password = password
      @items = []
      @rows = []
    end

    def append item
      @items << (item.nil? ? "" : item)
    end

    def << item
      append item
    end

    def next_row
      @rows << @items
      @items = []
    end

    def save row_id = nil
      return true if @rows.count == 0
      next_row
      row_id ||= worksheet.num_rows + 1

      set_worksheet_size(row_id + @rows.size)

      @rows.each_with_index do |items, row_index|
        items.each_with_index do |item, item_index|
          worksheet[row_id + row_index, item_index + 1] = item
        end
      end
      @items = []
      worksheet.save
    end

    def save! row_id = nil
      raise GSMetrics::Error.new('Save failed') unless save(row_id)
    end

    def set_worksheet_size size
      worksheet.max_rows = size unless worksheet.max_rows >= size
    end

    def session
      GoogleDrive.login(@email, @password)
    end

    def worksheet
      @worksheet ||= session.spreadsheet_by_title(@doc_title).worksheet_by_title(@worksheet_title)
    end
  end
end
