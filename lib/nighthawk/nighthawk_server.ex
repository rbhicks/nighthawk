defmodule Nighthawk.NighthawkServerMacros do
  @moduledoc """
  This is a simple proof of concept implementation of a DSL for
  creating declarative rules. In this case, three rules are for
  a theoretical SEO system are defined.

  Rule systems of this nature would normally require a separate
  system to provide the information that the rules act on and a
  mechanism to fix the rules correctly for all the that information.
  In this example, these parts are simulated. I.E., the helper
  functions provide single hard coded values.
  """

  defmacro __using__(_) do
    quote do
      import Nighthawk.NighthawkServerMacros
    end
  end
  
  # primary rule macro. this implements most
  # of the DSL for defining rules.
  # currently, we aren't using the rule name,
  # but we're passing it in as it will probably
  # be needed later for expanded functionality.
  defmacro defrule({_rule_name, _, _}, do: {:__block__,
                                           _,
                                           [{:conditions, _, _},
                                            {:actions, _, _}] = conditions_and_actions}) do
    quote do
      # the conditions are the head of conditions_and_actions
      # the actions are the tail of conditions_and_actions
      if (unquote (conditions_and_actions |> hd)) do
        unquote (conditions_and_actions |> tl)
      end
    end
  end

  # ultimately, this will produce a set of clauses
  # for an 'if' statement. to generate these clauses
  # we take each condition and wrap it in an 'and'
  # ast. 'process_conditions' handles all the cases
  # to produce the ast.
  defmacro conditions(do: block) do
    block |> process_conditions
  end

  # currently, this macro isn't strictly necessary.
  # however, this is here for two reasons:
  # - to make it consistent with conditions;
  #   this makes the rules easier to understand,
  #   read, and have a better "feel".
  # - in case we want to add functionality later,
  #   this will already be in place and we won't
  #   have to alter the other defrule code.
  defmacro actions(do: block) do
    block
  end

  # the first tuple element is  :__block__
  # so, we know we have multiple conditions
  def process_conditions({:__block__, _meta, conditions_ast}) do
    process_conditions(conditions_ast)
  end

  # the first tuple element wasn't :__block__
  # we know we have only one condition
  def process_conditions({function, _meta, arguments}) do
    {function, [context: Elixir, import: Kernel], arguments}
  end

  # pattern match to handle the case where there are only
  # two conditions. this way we can use pattern matching
  # instead of internal conditional logic
  def process_conditions([first_condition, second_condition]) do
    create_condition_ast_core(first_condition, second_condition)
  end

  # pattern match to handle the first two conditions where
  # there are more than two conditions. the first two need
  # to be handled separately since they form the core of
  # the condition ast. we're using pattern matching to do
  # this to avoid having a single function with conditional
  # logic to handle the special case of only two conditions
  # along with the cases of more than two conditions
  def process_conditions([head|tail]) do
    process_conditions(tail |> tl,
                       create_condition_ast_core(head, tail |> hd))
  end

  # this catches the last recursive call
  def process_conditions([], condition_logic), do: condition_logic

  # primary recursive processor
  def process_conditions([head|tail], conditions_ast) do
    process_conditions(tail,
      {:&&, [context: Elixir, import: Kernel],
       [
         conditions_ast,
         head
       ]})
  end

  # this ast structure is common to both initial cases; i.e., two
  # conditions and more than two conditions. this code is the same,
  # but it needs to be handled differently in the second case. as
  # such, move the common ast code here and call this both functions
  # that need it.
  def create_condition_ast_core(first_condition, second_condition) do
    {:&&,
     [context: Elixir, import: Kernel],
     [
       first_condition,
       second_condition
     ]}
  end
end

defmodule Nighthawk.NighthawkServer do
  use GenServer
  use Nighthawk.NighthawkServerMacros

  #
  # GenServer Callbacks
  #

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    """

    
    About to run three example rules for a theoretical
    SEO system. The rules do the following:
     - checks for a known bad source for a backlink
     - checks for meeting a minimum number of backlinks
     - checks for meeting a minimum number of internal links

    These rules are provided with hardcoded data that will
    cause each one to fire.
    """ |> IO.puts
    run_rules()
    {:ok, {}}
  end

  ##################################################################################
  ##################################################################################
  # this is where we define and run the rules
  #
  # as mentioned above, an implementation beyond a proof of concept would require
  # a separate system to gather the data and provide it to the unility functions.
  # also, it would have to be provide in such a way that rules could be applied
  # multiple times where necessary; e.g., the "bad_source_for_backlink" rule would
  # need to be run against all backlinks while the "not_enough_*" rules only need
  # to be run once.
  #
  # here we're only demonstrating the ability to use macros to create declarative
  # DSLs.
  ##################################################################################
  ##################################################################################
  
  def run_rules do
    defrule bad_source_for_backlink do
      conditions do
        backlink() == "http://some-bad-place.com/some-bad-path/some-bad-file.html"
      end
      actions do
        report "found bad backlink"
      end
    end

    defrule not_enough_backlinks do
      conditions do
        backlink_count() < 17
      end
      actions do
        report "not enough backlinks"
      end
    end

    defrule not_enough_internal_links do
      conditions do
        internal_link_count() < 37
      end
      actions do
        report "not enough internal links"
      end
    end
  end
  
  #
  # rule utilities
  #

  # fake implementation that just returns the bad
  # backlink source to test the rule
  def backlink do
    "http://some-bad-place.com/some-bad-path/some-bad-file.html"
  end

  # fake implementation that just returns a low backlink count
  def backlink_count do
    13
  end

  # fake implementation that just returns a low internal link count
  def internal_link_count do
    23
  end

  def report(message) do
    "+++++++++++++++++++++++++++++++++++++++" |> IO.puts
    message |> IO.puts
    "+++++++++++++++++++++++++++++++++++++++" |> IO.puts
    "" |> IO.puts
    "" |> IO.puts
  end  
end
