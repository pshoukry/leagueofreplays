defmodule Lor.S3 do
  use Ash.Api,
    extensions: [AshAdmin.Api]

  admin do
    show?(true)
  end

  resources do
    resource Lor.S3.Object
  end
end
