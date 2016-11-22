Handlebars = require('hbsfy/runtime')
gallery = require('./gallery')
data = require('../data/data')
headerTemplate = require('../hbs/header.hbs')
galleryTemplate = require('../hbs/gallery.hbs')
CONST =
	HEADER_SELECTOR: 'header'
	TYPE_ATTRIBUTE: 'data-gallery-type'

# Render header navigation
header = document.querySelector CONST.HEADER_SELECTOR
if header
	header.innerHTML = headerTemplate()

# Render all galleries on page
for node in document.querySelectorAll gallery.SELECTOR
	do (node) ->

		# Determine if dynamic data/template is enabled for current node
		if node.hasAttribute CONST.TYPE_ATTRIBUTE

			# See if data is available for current gallery type
			galleryType = node.getAttribute CONST.TYPE_ATTRIBUTE
			galleryData = data.galleries[galleryType]

			# Render gallery markup using handlebars
			if galleryData
				node.innerHTML += galleryTemplate(galleryData)

		# Initialize gallery component on current node
		new gallery(node)
