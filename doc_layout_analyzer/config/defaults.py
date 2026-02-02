DEFAULT_RULES = {
    "version": "1.0",
    "thresholds": {
        "architecture": {
            "figure_area_min": 0.22,
            "figure_count_min": 1,
            "figure_width_ratio_min": 0.55,
            "figure_area_strict": 0.30,
        },
        "db_schema": {
            "table_area_min": 0.22,
            "figure_area_min": 0.18,
            "table_width_ratio_min": 0.60,
            "body_area_max": 0.65,
        },
        "schedule": {
            "table_area_min": 0.28,
            "table_width_ratio_min": 0.70,
            "figure_area_min": 0.24,
            "figure_width_ratio_min": 0.70,
        },
        "chapter_start": {
            "title_area_min": 0.07,
            "body_area_max": 0.60,
            "title_position_top_ratio_max": 0.33,
        },
        "exclude": {
            "body_area_min": 0.78,
            "figure_table_area_max": 0.04,
        },
    },
    "scoring": {
        "architecture": 3,
        "db_schema": 3,
        "schedule": 2,
        "chapter_start": 2,
        "important_min": 4,
        "review_min": 2,
    },
    "confidence": {
        "low_confidence_median": 0.40,
        "downgrade_on_low_confidence": True,
    },
}

DEFAULT_LABEL_MAPPING = {
    "version": "1.0",
    "mapping": {
        "figure": ["figure", "image"],
        "table": ["table"],
        "title": [
            "doc_title",
            "paragraph_title",
            "figure_title",
            "table_caption",
            "figure_caption",
        ],
        "body": ["text", "abstract"],
        "formula": ["formula", "formula_number", "algorithm"],
        "reference": ["reference", "footnote"],
        "ignore": [
            "page_number",
            "header",
            "footer",
            "seal",
            "header_image",
            "footer_image",
            "sidebar_text",
            "table_of_contents",
        ],
    },
}

DEFAULT_PDF_CONVERSION = {
    "version": "1.0",
    "pdf_conversion": {
        "tool": "pymupdf",
        "dpi": 150,
        "format": "png",
        "color_mode": "rgb",
        "thread_count": 4,
    },
}

DEFAULT_RUN_MODE = {"version": "1.0", "mode": "accuracy"}

DEFAULT_VISUALS = {
    "colors": {
        "figure": "#F39C12",
        "table": "#3498DB",
        "title": "#2ECC71",
        "body": "#95A5A6",
        "other": "#B39DDB",
    },
    "highlight": {
        "important": "#E74C3C",
        "review": "#F1C40F",
    },
    "line_width": 2,
}
