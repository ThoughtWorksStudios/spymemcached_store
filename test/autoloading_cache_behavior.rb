require 'dependencies_test_helpers'

module AutoloadingCacheBehavior
  class E
  end
  class ClassFolder
    class NestedClass
    end

    class SiblingClass
    end
  end

  include DependenciesTestHelpers
  def test_simple_autoloading
    with_autoloading_fixtures do
      @cache.write('foo', E.new)
    end

    remove_constants(:E)
    ActiveSupport::Dependencies.clear

    with_autoloading_fixtures do
      assert_kind_of E, @cache.read('foo')
    end

    remove_constants(:E)
    ActiveSupport::Dependencies.clear
  end

  def test_two_classes_autoloading
    with_autoloading_fixtures do
      @cache.write('foo', [E.new, ClassFolder.new])
    end

    remove_constants(:E, :ClassFolder)
    ActiveSupport::Dependencies.clear

    with_autoloading_fixtures do
      loaded = @cache.read('foo')
      assert_kind_of Array, loaded
      assert_equal 2, loaded.size
      assert_kind_of E, loaded[0]
      assert_kind_of ClassFolder, loaded[1]
    end

    remove_constants(:E, :ClassFolder)
    ActiveSupport::Dependencies.clear
  end
end
