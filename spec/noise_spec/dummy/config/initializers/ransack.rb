Ransack.configure do |config|
  config.add_predicate 'dategteq', # Name your predicate
                       # What non-compound ARel predicate will it use? (eq, matches, etc)
                       arel_predicate: 'gteq',
                       # Force a specific column type for type-casting of supplied values.
                       # (Default: use type from DB column)
                       type: :date
  config.add_predicate 'datelteq', # Name your predicate
                       # What non-compound ARel predicate will it use? (eq, matches, etc)
                       arel_predicate: 'lteq',
                       # Force a specific column type for type-casting of supplied values.
                       # (Default: use type from DB column)
                       type: :date
end