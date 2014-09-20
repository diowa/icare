class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :concat, to: :@template

  %w(text_field email_field phone_field url_field text_area password_field collection_select select date_select time_zone_select datetime_select time_select).each do |method_name|
    define_method(method_name) do |name, *args|
      opts = args.extract_options!
      if %w(date_select datetime_select time_select time_zone_select).include?(method_name) && args.size == 0 || (%w(select).include?(method_name) && args.size == 1)
        args << opts
        args << { class: 'form-control' }
      else
        opts[:class] = ['form-control', opts[:class]].compact.join(' ')
        args << opts
      end
      bootstrap_options = opts.delete(:bootstrap_options) || {}
      form_classes = (options[:html] && options[:html][:class] || []).split
      if form_classes.include? 'form-horizontal'
        horizontal_tag(name, bootstrap_options) do
          super(name, *args)
        end
      elsif form_classes.include? 'form-inline'
        super(name, *args)
      else
        content_tag(:div, class: ['form-group',('has-error' if object.errors.include?(name))].compact.join(' ')) do
          html = label(name, opts.delete(:label))
          html << super(name, *args)
          html
        end
      end
    end
  end

  def button(name, *args)
    opts = args.extract_options!
    bootstrap_options = (opts.delete(:bootstrap_options) || {}).reverse_merge({ label_cols: 2, field_cols: 10 })
    form_classes = (options[:html] && options[:html][:class] || []).split
    opts.reverse_merge! class: 'btn btn-primary'
    args << opts
    if form_classes.include? 'form-horizontal'
      content_tag(:div, class: field_css_classes(bootstrap_options[:field_cols], bootstrap_options[:label_cols])) do
        super(name, *args)
      end
    else
      content_tag(:div, class: 'form-group') do
        super(name, *args)
      end
    end
  end

  def default_tag(method_name, name, *args)
    self.class.superclass.instance_method(method_name).bind(self).call(name, *args)
  end

  def check_box(name, *args)
    opts = args.extract_options!
    l = opts.delete(:label)
    opts.reverse_merge! class: 'checkbox'
    content_tag(:div, class: opts[:class]) do
      content_tag :label do
        super(name) + ' ' + (l || object.class.human_attribute_name(name))
      end
    end
  end

=begin
  def radio_button(name, group, *args)
    opts = args.clone.extract_options!
    label = opts.delete(:label)
    content_tag(:label, nil, class: ['radio', opts.delete(:class)].join(' ')) do
      super(name, group, opts) + ' ' + (label || object.class.human_attribute_name(name))
    end
  end
=end

  def error_messages
    if object.errors.full_messages.any?
      content_tag(:div, class: 'alert alert-block alert-danger fade in') do
        concat content_tag(:button, "&times;", { class: 'close', data: { dismiss: 'alert' }, type: 'button' }, false)
        concat content_tag(:h4, I18n.t('helpers.form.error'))
        object.errors.full_messages.map do |msg|
          concat msg
          concat tag(:br)
        end
      end
    end
  end

  private
  def horizontal_tag(name, label_cols: 2, field_cols: 10, render_label: true, help: false, opts: {})
    html = ''.html_safe
    html << label(name, opts.delete(:label), class: label_css_classes(label_cols)) if render_label
    html << content_tag(:div, class: field_css_classes(field_cols, (label_cols unless render_label))) do
      inner_html = yield
      content_tag(:p, @template.t(".#{name}_help"), class: 'help-block') if opts[:help]
      inner_html << content_tag(:p, object.errors.messages[name].to_sentence, class: 'help-block error-block') if object.errors.include?(name)
      inner_html
    end
    html
  end

  def label_css_classes(cols)
    ["col-sm-#{cols}", 'control-label'].compact.join(' ')
  end

  def field_css_classes(cols, offset = nil)
    ["col-sm-#{cols}", ("col-sm-offset-#{offset}" if offset)].compact.join(' ')
  end

  def objectify_options(options)
    super.except(:help, :bootstrap_options)
  end
end
