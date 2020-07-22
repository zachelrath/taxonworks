import ajaxCall from 'helpers/ajaxCall'

const CreateCollectingEvent = (ce) => ajaxCall('post', '/collecting_events.json', { collecting_event: ce })

const CreateGeoreference = (data) => ajaxCall('post', '/georeferences.json', { georeference: data })

const GetCollectingEvent = (id) => ajaxCall('get', `/collecting_events/${id}.json`)

const GetCollectingEvents = (params) => ajaxCall('get', '/collecting_events.json', { params: params })

const GetGeographicArea = (id) => ajaxCall('get', `/geographic_areas/${id}.json`)

const GetGeographicAreaByCoords = (lat, long) => ajaxCall('get', '/geographic_areas/by_lat_long', { params: { latitude: lat, longitude: long } })

const GetRecentCollectingEvents = () => ajaxCall('get', '/collecting_events.json', { params: { per: 10, recent: true } })

const GetDepictions = (id) => ajaxCall('get', `/collecting_events/${id}/depictions.json`)

const GetProjectPreferences = () => ajaxCall('get', '/project_preferences.json')

const UpdateCollectingEvent = (ce) => ajaxCall('patch', `/collecting_events/${ce.id}`, { collecting_event: ce })

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const LoadSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const DestroyDepiction = (id) => ajaxCall('delete', `/depictions/${id}`)

const DestroyCollectingEvent = (id) => ajaxCall('delete', `/collecting_events/${id}`)

export {
  CreateCollectingEvent,
  CreateGeoreference,
  DestroyDepiction,
  DestroyCollectingEvent,
  GetCollectingEvent,
  GetCollectingEvents,
  GetGeographicArea,
  GetRecentCollectingEvents,
  GetUserPreferences,
  GetDepictions,
  GetProjectPreferences,
  GetGeographicAreaByCoords,
  LoadSoftValidation,
  UpdateCollectingEvent,
  UpdateUserPreferences
}