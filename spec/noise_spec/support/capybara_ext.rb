module CapybaraExt
  def select_date(date, options = {})
    date      = Date.parse(date.to_s)
    id_prefix = find_label(options[:from])[:for]

    find(:xpath, ".//select[@id='#{id_prefix}_1i']").select(date.year.to_s)
    find(:xpath, ".//select[@id='#{id_prefix}_2i']").select(I18n.l date, :format => '%B')
    find(:xpath, ".//select[@id='#{id_prefix}_3i']").select(date.day.to_s)
  end

  def select_time(time, options)
    time      = Time.zone.parse(time.to_s)
    id_prefix = find_label(options[:from])[:for]

    find(:xpath, ".//select[@id='#{id_prefix}_4i']").select(time.hour.to_s.rjust(2, '0'))
    find(:xpath, ".//select[@id='#{id_prefix}_5i']").select(time.min.to_s.rjust(2, '0'))
  end

  def select_datetime(datetime, options = {})
    select_date(datetime, options)
    select_time(datetime, options)
  end

  def find_label(locator)
    return find(:xpath, ".//label[contains(.,'#{locator}')]")
  end
end

RSpec.configuration.include CapybaraExt
