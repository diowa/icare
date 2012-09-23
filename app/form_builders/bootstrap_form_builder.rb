class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :concat, to: :@template

  %w[text_field text_area password_field collection_select select date_select time_zone_select datetime_select].each do |method_name|
    define_method(method_name) do |name, *args|
      content_tag :div, class: "control-group#{" error" if object.errors.include?(name)}" do
        label_field(name, *args) +
        content_tag(:div, class: "controls") do
          if name == :nationality
            super(name, *args) +
            content_tag(:span, class: "inline-flag") do
              content_tag(:i, nil, id: "flag", class: ("flag-#{object.nationality.downcase}" if object.nationality?))
            end
          else
            super(name, *args)
          end +
          if object.errors.include?(name)
            content_tag(:span, class: "help-inline") do
              object.errors.messages[name].join(", ")
            end
          end +
          help_field(name, *args)
        end
      end
    end
  end

  def default_tag(method_name, name, *args)
    self.class.superclass.instance_method(method_name).bind(self).call(name, *args)
  end

  def check_box(name, *args)
    label(name, *args, class: "checkbox") do
      super(name) + " " + object.class.human_attribute_name(name)
    end
  end

  def radio_button(name, group, *args)
    opts = args.clone.extract_options!
    label = opts.delete(:label)
    content_tag(:label, nil, class: ["radio",opts.delete(:class)].join(" ")) do
      super(name, group, opts) + " " + (label || object.class.human_attribute_name(name))
    end
  end

  def collection_check_boxes(attribute, records, record_id, record_name)
    content_tag :div, class: "field" do
      @template.hidden_field_tag("#{object_name}[#{attribute}][]") +
      records.map do |record|
        element_id = "#{object_name}_#{attribute}_#{record.send(record_id)}"
        checkbox = @template.check_box_tag("#{object_name}[#{attribute}][]",
                                           record.send(record_id),
                                           object.send(attribute).include?(record.send(record_id)),
                                           id: element_id)
        checkbox + " " + @template.label_tag(element_id, record.send(record_name))
      end.join(tag(:br))
    end
  end

  def error_messages
    if object.errors.full_messages.any?
      content_tag(:div, class: "alert alert-block alert-error fade in") do
        concat content_tag(:button, "&times;", { class: "close", data: { dismiss: "alert" }, type: "button" }, false)
        concat content_tag(:h4, I18n.t("helpers.form.error"))
        object.errors.full_messages.map do |msg|
          concat msg
          concat tag(:br)
        end
      end
    end
  end

private

  def label_field(name, *args)
    options = args.extract_options!
    required = object.class.validators_on(name).any? { |v| v.kind_of? ActiveModel::Validations::PresenceValidator }
    label(name, options[:label], class: "control-label#{" required" if required}")
  end

  def help_field(name, *args)
    options = args.extract_options!
    content_tag(:p, class: "help-block") { @template.t(".#{name}_help") } if options[:help]
  end

  def objectify_options(options)
    super.except(:help)
  end

end
