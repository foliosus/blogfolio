module HighlightFix
  def self.included(base)
    base.class_eval do
      alias_method_chain :highlight, :href_fix
    end
  end

  def highlight_with_href_fix(text, phrases, *args)
    t = highlight_without_href_fix(text, phrases, *args)
    t.gsub!(/href="(.*?)<strong class="highlight">(.*?)<\/strong>(.*?)"/, 'href="\1\2\3"')
    t.gsub!(/title="(.*?)<strong class="highlight">(.*?)<\/strong>(.*?)"/, 'title="\1\2\3"')
    t
  end
end

ActionView::Helpers::TextHelper.send(:include, HighlightFix)