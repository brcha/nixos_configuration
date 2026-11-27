import QtQuick
import QtQuick.Shapes

// A card that grows out of a section (BarSection), as one shape with it, and
// slides out from under it as reveal goes from 0 to 1. Declare it before the
// section, so the section covers it, as wide as the window, with its top
// barRadius above the section's lower edge (atBottom, for the dock: its bottom
// barRadius below the section's upper edge). The content goes into host.
Item {
    id: root

    // x: the card's left edge; b0, b1: the ends of the section's body; atLeft,
    // atRight: the section is attached to that screen edge
    property var place: ({
            x: 0,
            b0: 0,
            b1: 0,
            atLeft: false,
            atRight: false
        })
    property real cardWidth: 0
    property real cardHeight: 0
    property real reveal: 0
    property bool atBottom: false
    readonly property alias host: hostItem
    default property alias content: hostItem.data

    // The outline, drawn for a top bar (atBottom flips it): the section's edge at
    // y = r. Its top reaches r into the section, under it, to fill the section's
    // corners. Where the card is wider than the section, a concave fillet joins
    // them and the card gets a rounded corner; where it is narrower, the fillet
    // hangs from the section. A card at a screen edge its section is attached to
    // runs along that edge.
    function path(): string {
        const p = place, r = Theme.barRadius, f = Theme.barFillet, W = width;
        const c0 = p.x, c1 = p.x + cardWidth, y1 = r + cardHeight;
        let d;
        if (p.atLeft && c0 <= 0) {
            d = `M 0 0 L 0 ${y1 + f} Q 0 ${y1} ${f} ${y1}`;
        } else {
            if (c0 < p.b0) {
                const rc = Math.min(r, (p.b0 - c0) / 2), k = Math.min(f, p.b0 - c0 - rc);
                d = `M ${p.b0} 0 L ${p.b0} ${r - k} Q ${p.b0} ${r} ${p.b0 - k} ${r} L ${c0 + rc} ${r} Q ${c0} ${r} ${c0} ${r + rc}`;
            } else {
                const k = Math.min(f, Math.max(0, c0 - p.b0 - r));
                d = `M ${c0 - k} 0 L ${c0 - k} ${r} Q ${c0} ${r} ${c0} ${r + k}`;
            }
            d += ` L ${c0} ${y1 - r} Q ${c0} ${y1} ${c0 + r} ${y1}`;
        }
        if (p.atRight && c1 >= W) {
            d += ` L ${W - f} ${y1} Q ${W} ${y1} ${W} ${y1 + f} L ${W} 0`;
        } else {
            d += ` L ${c1 - r} ${y1} Q ${c1} ${y1} ${c1} ${y1 - r}`;
            if (c1 > p.b1) {
                const rc = Math.min(r, (c1 - p.b1) / 2), k = Math.min(f, c1 - p.b1 - rc);
                d += ` L ${c1} ${r + rc} Q ${c1} ${r} ${c1 - rc} ${r} L ${p.b1 + k} ${r} Q ${p.b1} ${r} ${p.b1} ${r - k} L ${p.b1} 0`;
            } else {
                const k = Math.min(f, Math.max(0, p.b1 - c1 - r));
                d += ` L ${c1} ${r + k} Q ${c1} ${r} ${c1 + k} ${r} L ${c1 + k} 0`;
            }
        }
        return d + " Z";
    }

    height: Theme.barRadius + cardHeight + Theme.barFillet
    clip: true

    Item {
        id: body

        y: (root.atBottom ? 1 : -1) * (1 - root.reveal) * root.height
        width: root.width
        height: root.height

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            transform: Scale {
                origin.y: body.height / 2
                yScale: root.atBottom ? -1 : 1
            }

            ShapePath {
                fillColor: Theme.background
                strokeColor: "transparent"
                strokeWidth: 0

                PathSvg {
                    path: root.path()
                }
            }
        }

        Item {
            id: hostItem

            x: root.place.x
            y: root.atBottom ? Theme.barFillet : Theme.barRadius
            width: root.cardWidth
            height: root.cardHeight
        }
    }
}
