# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
Rails.application.configure do
  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  I18n.available_locales = [ :de, :en, :fr, :it ]
  config.i18n.default_locale = :en
  config.i18n.backend.class.send(:include, I18n::Backend::Fallbacks)
  config.i18n.fallbacks.map = {
    fr: [ :fr, :en ],
    de: [ :de, :en ],
    it: [ :it, :en ]
  }

# Configuration example with BUSiness specific translations and fall-backs
# This configuration allows to define a business specific language and to generate fall-baks for common terms
#   I18n.available_locales = [ :de_BUS, :fr_BUS, :it_BUS, :rm_BUS, :de, :fr, :it, :en, :rm ]
#   config.i18n.default_locale = :de_BUS
#   config.i18n.backend.class.send(:include, I18n::Backend::Fallbacks)
#   config.i18n.fallbacks.map = {
#      fr_BUS: [ :fr_BUS, :fr, :en ],
#      de_BUS: [ :de_BUS, :de, :en ],
#      it_BUS: [ :it_BUS, :it, :en ]
#   }

end
