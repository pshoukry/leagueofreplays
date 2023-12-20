defmodule Lor.Lol.Replay do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshStateMachine]

  postgres do
    table "lol_replays"

    repo Lor.Repo

    migration_types first_chunk_id: :smallint,
                    first_key_frame_id: :smallint,
                    last_chunk_id: :smallint,
                    last_key_frame_id: :smallint
  end

  identities do
    identity :game_id, [:game_id, :platform_id]
  end

  code_interface do
    define_for Lor.Lol
    define :read_all, action: :read
    define :create
    define :finish, action: :finish
    define :error, action: :error

    define :by_game_id_and_platform_id,
      action: :by_game_id_and_platform_id,
      args: [:platform_id, :game_id]
  end

  actions do
    defaults [:read, :create, :destroy]

    read :by_game_id_and_platform_id do
      get? true

      argument :platform_id, Lor.Lol.PlatformIds, allow_nil?: false
      argument :game_id, :string, allow_nil?: false

      prepare Lor.Lol.Replay.Preparations.FilterByGameIdAndPlatformId
    end

    update :finish do
      accept [:first_chunk_id, :last_chunk_id, :first_key_frame_id, :last_key_frame_id]

      change transition_state(:finished)
    end

    update :error do
      change transition_state(:errored)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :game_meta_data, :map, allow_nil?: false

    attribute :game_id, :integer, allow_nil?: false
    attribute :platform_id, Lor.Lol.PlatformIds, allow_nil?: false

    attribute :encryption_key, :string do
      allow_nil? false
      description "Key used to decrypt the spectator grid game data for playback"
    end

    attribute :first_chunk_id, :integer
    attribute :first_key_frame_id, :integer
    attribute :last_chunk_id, :integer
    attribute :last_key_frame_id, :integer

    attribute :state, :atom do
      allow_nil? false
      default :recording
      constraints one_of: [:recording, :finished, :errored]
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  state_machine do
    initial_states([:recording])
    default_initial_state(:recording)

    transitions do
      transition(:finish, from: :recording, to: :finished)
      transition(:error, from: :recording, to: :errored)
    end
  end

  relationships do
    has_many :key_frames, Lor.Lol.KeyFrame
    has_many :chunks, Lor.Lol.Chunk
  end
end
