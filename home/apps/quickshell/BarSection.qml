import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

// A bar section attached to the top screen edge: rounded lower corners, and
// concave fillets where it meets an edge. On a free side the fillet runs into
// the top edge; on a side attached to the screen's left or right edge it runs
// down that edge, below the section.
Item {
    id: root

    property bool atLeft: false
    property bool atRight: false
    default property alias content: row.data

    readonly property int fillet: Theme.barFillet
    readonly property real bodyX: atLeft ? 0 : fillet
    readonly property real bodyWidth: row.implicitWidth + 2 * Theme.barPadding

    implicitWidth: bodyWidth + (atLeft ? 0 : fillet) + (atRight ? 0 : fillet)
    implicitHeight: Theme.barHeight + (atLeft || atRight ? fillet : 0)

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.background
            strokeColor: "transparent"
            strokeWidth: 0

            PathSvg {
                path: {
                    const h = Theme.barHeight, f = root.fillet, r = Theme.barRadius;
                    const w = root.width, b0 = root.bodyX, b1 = root.bodyX + root.bodyWidth;
                    let d = `M 0 0 L ${w} 0`;
                    d += root.atRight
                        ? ` L ${w} ${h + f} Q ${w} ${h} ${w - f} ${h}`
                        : ` Q ${b1} 0 ${b1} ${f} L ${b1} ${h - r} Q ${b1} ${h} ${b1 - r} ${h}`;
                    d += root.atLeft
                        ? ` L ${f} ${h} Q 0 ${h} 0 ${h + f} Z`
                        : ` L ${b0 + r} ${h} Q ${b0} ${h} ${b0} ${h - r} L ${b0} ${f} Q ${b0} 0 0 0 Z`;
                    return d;
                }
            }
        }
    }

    RowLayout {
        id: row

        x: root.bodyX + Theme.barPadding
        height: Theme.barHeight
        spacing: 0
    }
}
