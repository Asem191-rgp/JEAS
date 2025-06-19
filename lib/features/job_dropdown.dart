import 'package:flutter/material.dart';

class JobDropDown extends StatefulWidget {
  final TextEditingController job;
  final Function(String) onJobSelected;
  const JobDropDown(this.job, {required this.onJobSelected, super.key});

  @override
  State<JobDropDown> createState() => _JobDropDownState();
}

class _JobDropDownState extends State<JobDropDown> {
  String? _selectedField;
  String? _selectedBranch;
  TextEditingController job = TextEditingController();
  final Map<String, List<String>> _branches = {
    'Creative Arts Field': [
      'Graphic Designer',
      'Illustrator',
      'Animator',
      'Art Director',
      'Film Director',
      'Photographer',
      'Writer/Author',
      'Musician',
      'Actor',
      'Fashion Designer',
      'Interior Designer',
      'Game Designer',
      'Creative Director',
      'Producer',
    ],
    'Visual Arts Crafts': [
      'Painting',
      'Drawing',
      'Sculpture',
      'Printmaking',
      'Ceramics',
      'Pottery',
      'Glassblowing',
      'Jewelry Making',
      'Woodworking',
      'Metalworking',
      'Textile Arts (e.g., weaving, knitting, embroidery)',
    ],
    'Decorative Crafts': [
      'Floral Design',
      'Interior Decorating',
      'Furniture Refinishing',
      'Upholstery',
      'Mosaic Art',
      'Papercraft (e.g., origami, card making)',
      'Candle Making',
      'Soap Making',
      'Calligraphy',
    ],
    'Textile Crafts': [
      'Sewing',
      'Quilting',
      'Tailoring',
      'Crocheting',
      'Knitting',
      'Embroidery',
      'Cross-Stitching',
      'Rug Making',
      'Tapestry Weaving',
      'Macramé',
    ],
    'Culinary Crafts': [
      'Baking',
      'Pastry Making',
      'Cake Decorating',
      'Chocolate Making',
      'Confectionery',
      'Brewing (e.g., beer, kombucha)',
      'Winemaking',
      'Cheese Making',
      'Fermentation (e.g., pickling, kimchi)',
      'Preserving (e.g., canning, jam making)',
    ],
    'Performing Arts Crafts': [
      'Acting',
      'Dance Choreography',
      'Costume Design',
      'Set Design',
      'Puppetry',
      'Makeup Artistry (for theater and film)',
      'Stage Lighting Design',
      'Prop Making',
      'Sound Design',
      'Stage Management',
    ],
    'Traditional Crafts': [
      'Blacksmithing',
      'Carpentry',
      'Masonry',
      'Basket Weaving',
      'Leatherworking',
      'Pottery',
      'Glassblowing',
      'Boat Building',
      'Saddle Making',
      'Bladesmithing',
    ],
    'DIY and Hobby Crafts': [
      'Scrapbooking',
      'Model Making (e.g., airplanes, trains)',
      'Card Making',
      'DIY Home Decor',
      'Gardening',
      'Home Brewing',
      'DIY Electronics',
      'Photography',
      'DIY Cosplay',
      'DIY Fashion Design',
    ],
  };
  @override
  void initState() {
    super.initState();
    job = widget.job;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Enter Your Job Field :",
          style: TextStyle(
            fontFamily: 'TiffanyHeavy',
            color: Colors.black,
            fontSize: 10,
          ),
          textAlign: TextAlign.left,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
          child: DropdownButtonFormField<String>(
            hint: const Text(
              "Enter Job Field :",
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'TiffanyHeavy',
                fontSize: 8,
              ),
            ),
            value: _selectedField,
            items: _branches.keys.map((String field) {
              return DropdownMenuItem(
                value: field,
                child: Text(
                  field,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedField = newValue;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.lightBlue),
              ),
              filled: true,
              fillColor: Colors.white30,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please don't leave the field empty!";
              }
              return null;
            },
          ),
        ),
        if (_selectedField != null)
          Column(
            children: [
              const Text(
                "Enter Branch of the Field :",
                style: TextStyle(
                  fontFamily: 'TiffanyHeavy',
                  color: Colors.black,
                  fontSize: 10,
                ),
                textAlign: TextAlign.left,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                child: DropdownButtonFormField<String>(
                  hint: const Text(
                    "Enter Job Branch :",
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'TiffanyHeavy',
                      fontSize: 8,
                    ),
                  ),
                  value: _selectedBranch,
                  items: _branches[_selectedField!]!.map((String branch) {
                    return DropdownMenuItem(
                      value: branch,
                      child: Text(
                        branch,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBranch = newValue;
                      widget.onJobSelected("$_selectedField($_selectedBranch)");
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.lightBlue),
                    ),
                    filled: true,
                    fillColor: Colors.white30,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please don't leave the field empty!";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
