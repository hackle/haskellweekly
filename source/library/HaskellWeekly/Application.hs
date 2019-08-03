module HaskellWeekly.Application
  ( application
  )
where

import qualified Data.Text
import qualified Data.Text.Encoding
import qualified Data.Text.Encoding.Error
import qualified HaskellWeekly.Handler.Advertising
import qualified HaskellWeekly.Handler.Base
import qualified HaskellWeekly.Handler.Episode
import qualified HaskellWeekly.Handler.Favicon
import qualified HaskellWeekly.Handler.HealthCheck
import qualified HaskellWeekly.Handler.Index
import qualified HaskellWeekly.Handler.Podcast
import qualified HaskellWeekly.Handler.Redirect
import qualified HaskellWeekly.Handler.Tachyons
import qualified HaskellWeekly.Type.Route
import qualified HaskellWeekly.Type.State
import qualified Network.HTTP.Types
import qualified Network.Wai

application :: HaskellWeekly.Type.State.State -> Network.Wai.Application
application state request respond =
  case (requestMethod request, requestRoute request) of
    ("GET", Just route) -> do
      response <- handle state route
      respond response
    _ -> respond notFoundResponse

requestMethod :: Network.Wai.Request -> String
requestMethod =
  Data.Text.unpack
    . Data.Text.Encoding.decodeUtf8With Data.Text.Encoding.Error.lenientDecode
    . Network.Wai.requestMethod

requestRoute :: Network.Wai.Request -> Maybe HaskellWeekly.Type.Route.Route
requestRoute =
  HaskellWeekly.Type.Route.stringToRoute
    . fmap Data.Text.unpack
    . Network.Wai.pathInfo

notFoundResponse :: Network.Wai.Response
notFoundResponse = HaskellWeekly.Handler.Base.textResponse
  Network.HTTP.Types.notFound404
  []
  "404 Not Found"

handle
  :: HaskellWeekly.Type.State.State
  -> HaskellWeekly.Type.Route.Route
  -> IO Network.Wai.Response
handle state route = case route of
  HaskellWeekly.Type.Route.RouteAdvertising ->
    HaskellWeekly.Handler.Advertising.advertisingHandler
  HaskellWeekly.Type.Route.RouteEpisode episodeNumber ->
    HaskellWeekly.Handler.Episode.episodeHandler episodeNumber
  HaskellWeekly.Type.Route.RouteFavicon ->
    HaskellWeekly.Handler.Favicon.faviconHandler state
  HaskellWeekly.Type.Route.RouteHealthCheck ->
    HaskellWeekly.Handler.HealthCheck.healthCheckHandler state
  HaskellWeekly.Type.Route.RouteIndex ->
    HaskellWeekly.Handler.Index.indexHandler
  HaskellWeekly.Type.Route.RoutePodcast ->
    HaskellWeekly.Handler.Podcast.podcastHandler
  HaskellWeekly.Type.Route.RouteRedirect redirect ->
    HaskellWeekly.Handler.Redirect.redirectHandler redirect
  HaskellWeekly.Type.Route.RouteTachyons ->
    HaskellWeekly.Handler.Tachyons.tachyonsHandler state
