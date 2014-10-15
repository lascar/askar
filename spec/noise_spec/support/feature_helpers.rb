module HelperMethods
  # Helpers for javascript interactions in acceptance specs
  module Feature
    # @author michaelbrawn
    # @version https://gist.github.com/thijsc/1391107#comment-1237961
    # modif for reek complaint
    # @param item_text [String] the choosen value
    # @param options [Hash] options[:from] the choosen field
    # @return not important as it's for changing the state of the dom
    def select_from_chosen(item_text, options)
      field = find_field(options[:from], visible: false)
      field_id = field && field[:id]
      page.execute_script <<-script
        var optValue = $("##{field_id} option:contains('#{item_text}')").val();
        var value = [optValue];
        if ($('##{field_id}').val()) {
          $.merge(value, $('##{field_id}').val());
        }
        $('##{field_id}').val(value).trigger('chosen:updated');
      script
    end

    def find_headline(text)
      xpath = "//div[contains(@class,'headline')]//div[contains(.,'#{text}')]"
      find(:xpath, xpath)
    end
  end
end
