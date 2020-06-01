defmodule Nighthawk.NighthawkServerMacros do

  defmacro __using__(_) do
    quote do
      import Nighthawk.NighthawkServerMacros
    end
  end

  defmacro defrule({rule_name, _, _}, do: block) do
    # IO.puts "§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§"
    # IO.puts "§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§"
    # IO.inspect rule_name
    # IO.puts "§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§"
    # IO.inspect block
    # IO.puts "§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§"
    # IO.puts "§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§"
    quote do
      unquote block
    end
  end

  defmacro conditions(do: block) do
    quote do
      unquote do
        block |> process_conditions |> IO.inspect
      end
    end
  end

  defmacro actions(do: block) do
    # IO.puts "*********************************"
    # IO.puts "*********************************"
    # IO.inspect block
    # IO.puts "*********************************"
    # IO.puts "*********************************"
  end

  # the first tuple element is  :__block__
  # so, we know we have multiple conditions
  def process_conditions({:__block__, _meta, conditions_ast}) do
    process_conditions(conditions_ast)
  end

  # the first tuple element wasn't :__block__
  # we know we have only one condition
  def process_conditions({function, _meta, arguments}) do
    {function, [context: Elixir, import: Kernel], [true, true]}    
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


    # - backlinks
    # -- backlink_total
    # -- bridgelink_candidate_total
    # - internal_links
    # -- internal_link_total
    # source: https//:someplace.com/some-path/some-page.html?some-query-string

    defrule bad_source_for_backlink do
      conditions do
        true == true
        13 < 17
        17 > 11
        false == false
      end
      actions do
        IO.puts "$%$%$%$%$%$%$%$%$%$%$%$%"
        IO.puts "@@@@@@@@@@@@@@@@@@@@@@@@"
      end
    end

    # {:if, [context: Elixir, import: Kernel],
    #  [
    #    true,
    #    [
    #      do: {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [],
    #           ["$$$$$$$$$$"]}
    #    ]
    #  ]}
        
    # {:&&, [context: Elixir, import: Kernel],
    #  [
    #    {:&&, [context: Elixir, import: Kernel],
    #     [
    #       {:&&, [context: Elixir, import: Kernel],
    #        [
    #          {:==, [context: Elixir, import: Kernel], [true, true]},
    #          {:<, [context: Elixir, import: Kernel], [13, 17]}
    #        ]},
    #       {:>, [context: Elixir, import: Kernel], [17, 11]}
    #     ]},
    #    {:==, [context: Elixir, import: Kernel], [false, false]}
    #  ]}
    

    IO.puts "±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±"
    {:ok, {}}
  end



end
