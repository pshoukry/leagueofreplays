defmodule Lor.Lol.Participant do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lol_participants"

    repo Lor.Repo

    references do
      reference :match, on_delete: :delete
      reference :opponent_participant, on_delete: :delete
    end
  end

  code_interface do
    define_for Lor.Lol
    define :create_from_api, args: [:match_id, :participant_data]
    define :update_opponent_participant, args: [:participants, :participant]
    define :read_all, action: :read
    define :list_replays, action: :list_replays, args: [:filter]
  end

  actions do
    defaults [:read]

    read :list_replays do
      argument :filter, :map, allow_nil?: true

      pagination do
        keyset? true
        default_limit 20
      end

      prepare Lor.Lol.Participant.Preparations.FilterSortReplay
    end

    create :create_from_api do
      accept [:match_id]

      argument :participant_data, :map do
        allow_nil? false
      end

      argument :existing_summoners, {:array, :struct} do
        # TODO update when instance_of is stable
        # constraints [instance_of: Lor.Lol.Summoner]
        allow_nil? false
      end

      argument :created_summoners, {:array, :struct} do
        # TODO update when instance_of is stable
        # constraints [items: [instance_of: Lor.Lol.Summoner]]
        allow_nil? false
      end

      change Lor.Lol.Participant.Changes.CreateFromApi
    end

    update :update_opponent_participant do
      accept []

      argument :participants, {:array, :map} do
        allow_nil? false
      end

      change Lor.Lol.Participant.Changes.UpdateOpponentParticipant
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :team_id, :integer, allow_nil?: false
    attribute :kills, :integer, allow_nil?: false
    attribute :deaths, :integer, allow_nil?: false
    attribute :assists, :integer, allow_nil?: false
    attribute :champion_id, :integer, allow_nil?: false
    attribute :gold_earned, :integer, allow_nil?: false
    attribute :summoners, {:array, :integer}, allow_nil?: false
    attribute :items, {:array, :integer}, allow_nil?: false
    attribute :team_position, :string, allow_nil?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :team_position_order,
              :integer,
              expr(
                fragment(
                  "ARRAY_POSITION(ARRAY['TOP', 'JUNGLE', 'MIDDLE', 'TOP', 'UTILITY'], ?)",
                  team_position
                )
              )
  end

  relationships do
    belongs_to :match, Lor.Lol.Match do
      allow_nil? false
      attribute_type :uuid
      attribute_writable? true
    end

    belongs_to :summoner, Lor.Lol.Summoner do
      allow_nil? false
      attribute_type :uuid
      attribute_writable? true
    end

    belongs_to :opponent_participant, Lor.Lol.Participant do
      attribute_type :uuid
      attribute_writable? true
    end
  end
end
